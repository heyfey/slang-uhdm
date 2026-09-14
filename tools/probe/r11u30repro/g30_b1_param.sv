// r11u30 arm b1 — `inside` in DECLARATION contexts, the ones whose def-view
// expression can reach the SYNTAX emitter rather than the AST one: a net
// declaration assignment, a variable initialiser, a subroutine DEFAULT
// ARGUMENT, a class property initialiser, a continuous assign.
//
// MEASURED AND REMOVED FROM THIS ARM (Surelog rejects the source outright, 10
// SYNTAX errors, no database -- `constant_expression` in `SV3_1aParser.g4` has
// no INSIDE alternative): `inside` in a module parameter-port default, in a
// `localparam`/`parameter` value, and in a GENERATE-IF condition.  Those three
// elaboration-time contexts are therefore UNREACHABLE on the golden side and
// cannot be a face of this law.
module b30 #(parameter int PW30 = 4)
            (input logic [3:0] din30, output logic o30);
  localparam int LO30 = 2;
  localparam int HI30 = 9;
  wire wq30 = (din30 inside {[4'd1:4'd3]});
  wire wf30 = (din30 inside {4'd1, 4'd3});
  wire wm30 = (din30 inside {4'd1, [4'd4:4'd6], 4'd7});
  int vi30 = (PW30 inside {[LO30:HI30]}) ? 1 : 0;
  logic o2_30;
  assign o2_30 = din30 inside {[4'd2:4'd5]};
  assign o30 = wq30 ^ wf30 ^ wm30 ^ o2_30;
  function automatic bit fd30(int vv30 = 3, bit bb30 = (3 inside {[1:4]}));
    return vv30 inside {[LO30:HI30]};
  endfunction
  class cp30;
    bit pv30 = (2 inside {1, [3:5]});
  endclass
endmodule
