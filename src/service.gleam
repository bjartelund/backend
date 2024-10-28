import gleam/erlang/process.{type Subject}
import gleam/list
import gleam/otp/actor
import gleam/set.{type Set}

pub fn new() -> Result(Subject(Message), actor.StartError) {
  actor.start(set.new(), handle_message)
}

pub fn add_item(collection: Subject(Message), item: String) {
  actor.send(collection, AddItem(item))
}

pub fn get_item(collection: Subject(Message)) -> Result(String, Nil) {
  actor.call(collection, GetItem(_), 1000)
}

pub type Message {
  AddItem(item: String)
  GetItem(reply_with: Subject(Result(String, Nil)))
}

fn handle_message(
  message: Message,
  collection: Set(String),
) -> actor.Next(Message, Set(String)) {
  case message {
    AddItem(item) -> actor.continue(set.insert(collection, item))
    GetItem(client) -> {
      let response = collection |> set.to_list |> list.last
      process.send(client, response)
      actor.continue(collection)
    }
  }
}
