// LAW B road F: leaf port typed by a package struct (the pre-existing vpiNetType face, recorded)
package p; typedef struct packed { logic a; logic b; } s_t; endpackage
module leaf (output p::s_t l); assign l = '0; endmodule
module orphan ();
  p::s_t r;
  leaf u_l (.l(r));
endmodule
module dut (output logic [31:0] o);
  if (0) begin : g
    orphan u_o ();
  end
  assign o = 32'd0;
endmodule
