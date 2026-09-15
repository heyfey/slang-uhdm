// v4_use35 — THE USE axis and the shapes the law does NOT gate: an
// assignment-pattern localparam of the type-parameter type (the FLATTEN CLONE
// Surelog reduces), a port of that type, a cast, a function-local variable, an
// anonymous ENUM default, a member with an UNPACKED dimension, a re-passed
// type parameter, and a parameterised class specialised explicitly.
package cfg4v35;
  localparam int PW = 12;
  typedef struct packed {
    int XLEN;
  } cfg_t;
  localparam cfg_t Cfg = '{XLEN: 32};
endpackage

module child4v35 #(parameter type CT = struct packed { logic [3:0] d; })
                 (input CT pin);
  CT cv;
  always_comb cv = pin;
endmodule

module v4_use35 #(parameter int W = 8) (input logic clk, output logic o);
  // the law's cell
  localparam type it_t = struct packed {
    logic [cfg4v35::Cfg.XLEN-1:0] x;
    logic [W-1:0]                 y;
  };
  // the ASSIGNMENT-PATTERN localparam of that type — Surelog's
  // flattenPatternAssignments CLONES the typespec and reduces the clone
  localparam it_t IT = '{x: '0, y: '0};
  it_t v;
  // a CAST through the same type
  localparam int Q = int'(IT.y);
  // a function-local variable of the type
  function automatic int f4v(input int a);
    it_t lv;
    lv = '0;
    return a + int'(lv.y);
  endfunction
  // an anonymous ENUM as a type parameter default — NOT gated by this law
  localparam type e_t = enum logic [W-1:0] { E_A, E_B };
  e_t ev;
  // a member with an UNPACKED dimension inside the default
  localparam type arr_t = struct packed {
    logic [W-1:0] a;
  };
  arr_t arr [W-1:0];
  // re-pass the type to a child's own type parameter
  child4v35 #(.CT(it_t)) u_c (.pin(v));
  int r;
  always_comb begin
    v = IT;
    ev = E_A;
    r = f4v(Q);
    o = ^{v, ev, r, arr[0]};
  end
endmodule
