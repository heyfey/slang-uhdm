// § modFnLitLeftoverValueGate302v
// vl16: a case on the argument writes the member from different literals; two calls take two arms
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } c_t;
endpackage
module dut(output logic o);
  function automatic pk::c_t mk(input logic [1:0] k);
    pk::c_t c; c.a = 1;
    case (k)
      2'd0: c.b = 10;
      2'd1: c.b = 11;
      default: c.b = 12;
    endcase
    return c;
  endfunction
  localparam pk::c_t L = mk(2'd1);
  localparam logic [7:0] LB = L.b;
  assign o = 1'b0;
endmodule
