// v11u49 arm v4 — LAW B: select written inside a CLASS body in a package
// (the UVM shape), and a select on ANOTHER package's parameter from inside a package.
package r;
  typedef struct packed { logic [7:0] CTL; logic [7:0] DAT; } rb_t;
  localparam rb_t RCLS = '{CTL:8'd1, DAT:8'd2};   // selected only in a class method
  localparam rb_t RXPK = '{CTL:8'd3, DAT:8'd4};   // selected only from package s
  localparam rb_t RNON = '{CTL:8'd5, DAT:8'd6};   // never selected
  class C;
    function int m(); return RCLS.DAT; endfunction
  endclass
endpackage
package s;
  function automatic int h(); return r::RXPK.DAT; endfunction
endpackage
module v4 (output logic [31:0] o);
  assign o = r::RNON.CTL + s::h();
endmodule
