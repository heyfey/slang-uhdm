// § paramInitMemberSelLvShape294
// a class localparam reading a select of a class struct parameter
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; logic [1:0][3:0] m; } c_t;
  localparam c_t C = '{u: 8'h35, d: 8'hA6, m: 8'h21};
endpackage
module dut(output logic [7:0] o);
  class cl #(parameter pk::c_t P = pk::C);
    localparam logic B = P.d[3];
    static function logic g(); return B; endfunction
  endclass
  assign o = cl#()::g();
endmodule
