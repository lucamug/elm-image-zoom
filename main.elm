module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode exposing (..)


--import Mouse


type alias MouseMoveData =
    { offsetX : Int
    , offsetY : Int
    , offsetHeight : Float
    , offsetWidth : Float
    }


emptyMouseMove : MouseMoveData
emptyMouseMove =
    { offsetX = 0
    , offsetY = 0
    , offsetHeight = 0
    , offsetWidth = 0
    }


decoder : Decoder MouseMoveData
decoder =
    map4 MouseMoveData
        (at [ "offsetX" ] int)
        (at [ "offsetY" ] int)
        (at [ "target", "offsetHeight" ] float)
        (at [ "target", "offsetWidth" ] float)



-- MODEL


type alias Model =
    { zoomUrl : Maybe String
    , zoomMouseMove : Maybe MouseMoveData
    , imageSrc : String
    }


init : ( Model, Cmd Msg )
init =
    ( { zoomUrl = Nothing
      , zoomMouseMove = Nothing
      , imageSrc = "sea.png"
      }
    , Cmd.none
    )



-- MESSAGES


type Msg
    = MouseEnter String
    | MouseLeave String
    | MouseMove MouseMoveData



-- VIEW


view : Model -> Html Msg
view model =
    div [ style [ ("position" => "relative") ] ]
        [ node "style" [] [ text css ]
        , viewZoomCanvas model
        , img
            [ id "zoomable"
            , onMouseEnter (MouseEnter model.imageSrc)
            , onMouseLeave (MouseLeave model.imageSrc)
            , on "mousemove" (Decode.map MouseMove decoder)
            , style [ ( "cursor", "none" ) ]
            , src model.imageSrc
            ]
            []
        ]


viewZoomCanvas : Model -> Html Msg
viewZoomCanvas model =
    case model.zoomUrl of
        Just data ->
            let
                url =
                    Maybe.withDefault "" model.zoomUrl

                data =
                    Maybe.withDefault emptyMouseMove model.zoomMouseMove

                x =
                    toString (round ((toFloat data.offsetX) / data.offsetWidth * 100))

                y =
                    toString (round ((toFloat data.offsetY) / data.offsetHeight * 100))
            in
                div
                    []
                    [ div
                        [ id "zoomArea"
                        , style
                            [ ( "position", "absolute" )
                            , ( "top", toString (data.offsetY - 50) ++ "px" )
                            , ( "left", toString (data.offsetX - 50) ++ "px" )
                            , ( "border", "1px solid #d4d4d4" )
                            , ( "width", "100px" )
                            , ( "height", "100px" )
                            , ( "border-radius", "5px" )
                            , ( "pointer-events", "none" )
                            , ( "background-color", "rgba(255, 255, 255, 0.2)" )
                            , ( "opacity", "1" )
                            , ( "z-index", "1" )
                            ]
                        ]
                        [ text "" ]
                    , div
                        [ id "zoomCanvas"
                        , style
                            [ ( "background-position", x ++ "% " ++ y ++ "%" )
                            , ( "background-image", "url(" ++ url ++ ")" )
                            ]
                        ]
                        []
                    ]

        Nothing ->
            div
                []
                [ div [] []
                , div
                    [ id "zoomCanvas"
                    , class "disabled"
                    ]
                    []
                ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MouseEnter data ->
            ( { model | zoomUrl = Just data }, Cmd.none )

        MouseLeave data ->
            ( { model | zoomUrl = Nothing }, Cmd.none )

        MouseMove data ->
            ( { model | zoomMouseMove = Just data }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        []



-- MAIN


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


css : String
css =
    """
body {
    color: #888;
    margin: 0;
    font-family: sans-serif;
    background-color: #333;
}
#zoomable {
    width: 300px;
}
#zoomCanvas {
    position: absolute;
    width: 500px;
    height: 400px;
    border: 1px solid #d4d4d4;
    left: 320px;
    background-repeat: no-repeat;
    opacity: 1;
    visibility: visible;
    transition: visibility 0.3s, opacity 0.3s;
}
#zoomCanvas.disabled {
    opacity: 0;
    visibility: hidden;
}
"""
