// r10v118 arm H — EVERY operation-typespec stamp home crossed with operand
// kinds.  Names/numbers/case deliberately UNPATTERNED (no a_t/b_t/c_t grid).
`define WRAP_IT(TXT) $display("%s", {"<", TXT, ">"})
`define TERN_MAC(Q) {"m:", ((Q) > 3 ? "hi" : "lo"), "."}

package Grommet;
  parameter BAREWORD = "unsized";              // implicit-string parameter
  typedef enum bit [2:0] { Zeta = 3, Yarn = 5 } Knot_e;

  function automatic string pkgfn(int Nib);    // PKGFUNC home
    string R;
    R = {"a", (Nib == 0 ? "" : ", ")};                 // ternary, empty arm
    R = {R, ((Nib > 9) ? "big" : (Nib > 4 ? "mid" : "small"))};  // nested ternary
    R = {R, {"in", "ner"}};                            // inner concat operand
    R = {R, {3{"ab"}}};                                // replication operand
    R = {R, BAREWORD};                                 // implicit-string param
    R = {R, (Nib > 2 ? {"x", "y"} : "z")};             // concat inside ternary
    R = {R, !("q")};                                   // UNARY op operand
    R = {R, ("w" == "w")};                             // BINARY op operand
    R = {R, `TERN_MAC(Nib)};                           // MACRO-EXPANDED span
    return R;
  endfunction

  task automatic pkgtsk(int Nib, output string Ret);   // PKGTASK home
    Ret = {"t", (Nib & 1 ? "odd" : "even"), `TERN_MAC(Nib)};
  endtask

  class Filbert;
    int Cardinal = 7;
    function string inbody();                          // CLASSMETHOD_INBODY
      return {"ib:", (Cardinal > 3 ? "gt" : "le"), {2{"!"}}};
    endfunction
    extern function string oobfn();                    // OOB_FUNC
    extern task oobtsk(output string Q);               // OOB_TASK
    static function string statfn(int K);               // STATIC method
      return {"sf:", (K == 1 ? "one" : "many")};
    endfunction
    function new();                                     // CONSTRUCTOR
      Cardinal = 11;
      $display("%s", {"ctor:", (Cardinal > 5 ? "hi" : "lo")});
    endfunction
  endclass
  function string Filbert::oobfn();
    return {"of:", (Cardinal < 99 ? "in" : "out"), `TERN_MAC(Cardinal)};
  endfunction
  task Filbert::oobtsk(output string Q);
    Q = {"ot:", (Cardinal != 0 ? "nz" : "z")};
  endtask
endpackage

function automatic string unitfn(int Grit);            // $unit FREEFUNC home
  return {"u:", (Grit > 0 ? "pos" : "nonpos")};
endfunction

interface Cordage(input logic Clk);                    // INTERFACE home
  string Banner;
  always_comb Banner = {"if:", (Clk === 1'b1 ? "on" : "off")};
  function automatic string ifn(int V);
    return {"ifn:", (V > 1 ? "many" : "one")};
  endfunction
endinterface

program Trestle;                                       // PROGRAM home
  string Chit;
  initial Chit = {"pg:", (2 > 1 ? "y" : "n")};
endprogram

module Bulwark #(parameter int Girth = 6) (input logic Ck);
  localparam string PARINIT = {"pi:", (Girth > 2 ? "big" : "wee")};  // PARAMINIT (never-stamp)
  string Slate, Kerf;
  wire [7:0] Notch;
  Grommet::Filbert Fb;

  assign Notch = {4'hA, (Girth > 3 ? 4'h1 : 4'h2)};    // NON-string concat: never-stamp
  // CONTASSIGN home, string concat -- string vars cannot take assign, use a fn
  always_comb Slate = {"ac:", (Ck ? "1" : "0"), `TERN_MAC(Girth)};   // ALWAYS_COMB
  always @(Ck) Kerf = {"aa:", (Girth == 6 ? "six" : "other")};       // ALWAYS
  always_ff @(posedge Ck) Kerf <= {"af:", (Girth > 0 ? "p" : "n")};  // ALWAYS_FF
  initial begin                                                      // INITIAL
    Fb = new();
    Slate = {"in:", (Girth < 100 ? "lt" : "ge")};
    `WRAP_IT(Grommet::pkgfn(Girth));
    Grommet::pkgtsk(Girth, Slate);
    $display("%s%s%s%s", Fb.inbody(), Fb.oobfn(), Grommet::Filbert::statfn(Girth), unitfn(Girth));
    Fb.oobtsk(Slate);
  end
  final $display("%s", {"fi:", (Girth > 1 ? "gt" : "le")});          // FINAL

  for (genvar Gi = 0; Gi < 2; Gi++) begin : Weave                    // GENSCOPE for
    string Tag;
    always_comb Tag = {"gs:", (Gi == 0 ? "zero" : "one")};
    initial $display("%s", {"gi:", (Gi > 0 ? "hi" : "lo")});
    function automatic string gfn();
      return {"gf:", (Gi == 1 ? "b" : "a")};
    endfunction
  end
  if (Girth > 3) begin : Sifted                                      // GENSCOPE if
    string Mark;
    always_comb Mark = {"gc:", (Girth > 5 ? "many" : "few")};
  end
endmodule
