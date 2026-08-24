// r10v118 arm X — CONTEXTS/POSITIONS for the string concat, plus the remaining
// slang routes that can build an Explicit conversion to `string`.
package Tuffet;
  typedef string Sobriquet;
  parameter Fledge = "unsized_p";
endpackage

module Rampart #(parameter int Hasp = 4) (input logic Pulse, output string Emit);
  import Tuffet::*;
  // PARAMETER INIT position (never-stamp control)
  localparam string PINIT = {"p", (Hasp > 2 ? "A" : "B")};
  // PARAMETER OVERRIDE position on a child instance
  string Grange, Hollow;
  logic [3:0] Plain;
  int Tally;
  string Bin [3];
  event Nudge;

  // never-stamp: plain integral concat with a ternary operand
  assign Plain = {2'b10, (Hasp > 1 ? 2'b01 : 2'b11)};

  function automatic string retfn(int Z);
    // RETURN position
    return {"r", (Z > 0 ? "+" : "-")};
  endfunction
  function automatic string argfn(string S = {"d", (1 ? "y" : "n")});  // DEFAULT ARG
    return S;
  endfunction

  always_comb Emit = {"o", (Pulse ? "1" : "0")};                 // OUTPUT PORT driver
  initial begin
    Grange = {"c", (Hasp == 4 ? "four" : "other")};              // plain
    case ({"k", (Hasp > 0 ? "y" : "n")})                          // CASE EXPRESSION
      "ky": Tally = 1;
      default: Tally = 0;
    endcase
    unique case (Tally)
      1: Hollow = {"u", (Tally > 0 ? "g" : "l")};                 // CASE ITEM stmt
      default: Hollow = "z";
    endcase
    foreach (Bin[i]) Bin[i] = {"f", (i > 1 ? "hi" : "lo")};       // FOREACH body
    Hollow = argfn({"a", (Hasp > 3 ? "q" : "w")});                // CALL ARG
    Hollow = retfn(Hasp);
    Hollow = {Hollow, Fledge};                                    // implicit-string param
    // STREAMING concat into a string context (ConversionKind::StreamingConcat)
    // written cast via a PACKAGE typedef inside a string concat
    Hollow = {Hollow, Sobriquet'(Hasp)};
    ->Nudge;
    @(Nudge) Grange = {"e", (Hasp > 0 ? "hi" : "lo")};            // TIMING-CONTROLLED stmt
    #1 Grange = {"d", (Hasp > 0 ? "hi" : "lo")};                  // DELAYED stmt
  end
  // ASSERTION with a string concat in the action block
  always @(posedge Pulse)
    assert (Hasp > 0) else $error("%s", {"as", (Hasp > 9 ? "big" : "sml")});
endmodule
