defmodule Mastery.Boundary.QuizSession do
  alias Mastery.Core.{Quiz, Response}

  use GenServer

  def init({quiz, email}), do: {:ok, {quiz, email}}

  def handle_call(:select_question, _from, {old_quiz, email}) do
    quiz = Quiz.select_question(old_quiz)
    {:reply, quiz.current_question.asked, {quiz, email}}
  end

  def handle_call({:answer_question, answer}, _from, {quiz, email}) do
    quiz
    |> Quiz.answer_question(Response.new(quiz, email, answer))
    |> Quiz.select_question()
    |> maybe_finish(email)
  end

  def maybe_finish(nil, _email), do: {:stop, :normal, :finished, nil}

  def maybe_finish(quiz, email),
    do: {:reply, {quiz.current_question.asked, quiz.last_response.correct}, {quiz, email}}

  def select_question(session), do: GenServer.call(session, :select_question)
  def answer_question(session, answer), do: GenServer.call(session, {:answer_question, answer})
end
