module Main where

import Prelude (Unit, bind, const, show, pure, (-), (+), ($), (<<<))
import Control.Monad.Eff (Eff)
import Control.Monad.Aff (attempt)
import Data.Array (head)
import Data.Maybe (Maybe(Just))
import Data.Either (Either(..), either)
import Data.Argonaut (class DecodeJson, decodeJson, (.?))
import Pux (CoreEffects, EffModel, noEffects, renderToDOM, start)
import Pux.Html (Html, text, button, span, div)
import Pux.Html.Events (onClick)
import Network.HTTP.Affjax (AJAX, get)


data Action = Increment | Decrement | GetValue | RecvValue (Either String Todos)

type State = Int

type Todos = Array Todo

newtype Todo = Todo { id :: Int , title :: String }

instance decodeJsonTodo :: DecodeJson Todo where
  decodeJson json = do
    obj <- decodeJson json
    id <- obj .? "id"
    title <- obj .? "title"
    pure $ Todo { id: id, title: title }

  
update :: Action -> State -> EffModel State Action (ajax :: AJAX)
update Increment count = noEffects $ count + 1
update Decrement count = noEffects $ count - 1
update (RecvValue a) count =
  noEffects $ case a of
                Right ts -> case head ts of
                             Just (Todo t) -> t.id
                             _ -> count
                _ -> count
update GetValue count =
  { state: count
  , effects: [do
                 res <- attempt $ get "http://jsonplaceholder.typicode.com/users/1/todos"
                 let decode r = decodeJson r.response :: Either String Todos
                 let todos = either (Left <<< show) decode res
                 pure $ RecvValue todos
             ]
  }

view :: State -> Html Action
view count =
  div
    []
    [ button [ onClick (const Increment) ] [ text "Increment" ]
    , span [] [ text (show count) ]
    , button [ onClick (const Decrement) ] [ text "Decrement" ]
    , button [ onClick (const GetValue) ] [ text "GetValue" ]
    ]

main :: Eff (CoreEffects (ajax :: AJAX)) Unit
main = do
  app <- start
    { initialState: 0
    , update: update
    , view: view
    , inputs: []
    }

  renderToDOM "#app" app.html
