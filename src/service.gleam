import gleam/dynamic
import gleam/erlang/process.{type Subject}
import gleam/list
import gleam/otp/actor
import gleam/set.{type Set}
import sqlight.{type Connection}

pub fn new(connection: Connection) -> Result(Subject(Message), actor.StartError) {
  let assert Ok(_) = sqlight.exec("CREATE TABLE links (url TEXT)", connection)
  actor.start(connection, handle_message)
}

pub fn add_item(connection: Subject(Message), item: String) {
  actor.send(connection, AddItem(item))
}

pub fn get_item(connection: Subject(Message)) -> Result(String, Nil) {
  actor.call(connection, GetItem(_), 1000)
}

pub type Message {
  AddItem(item: String)
  GetItem(reply_with: Subject(Result(String, Nil)))
}

fn handle_message(
  message: Message,
  connection: Connection,
) -> actor.Next(Message, Connection) {
  case message {
    AddItem(item) -> {
      let sql = "INSERT INTO links (url) VALUES ('" <> item <> " ')"
      let assert Ok(_) = sqlight.exec(sql, connection)
      actor.continue(connection)
    }
    GetItem(client) -> {
      let sql = "SELECT url,1 from links LIMIT 1"
      let assert Ok(response) =
        sqlight.query(sql, connection, [], dynamic.element(0, dynamic.string))
      let last = response |> list.last

      process.send(client, last)
      actor.continue(connection)
    }
  }
}
