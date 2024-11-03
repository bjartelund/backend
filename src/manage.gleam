import gleam/erlang/process.{type Subject}
import gleam/otp/actor
import gleam/dict.{type Dict }

pub type Message {
  AddItem(actor: String)
  GetItem(reply_with: Subject(Result(String, Nil)))
}
