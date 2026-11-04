// § pureProtoInlineAggSpans301
package pk;
  virtual class b;
    pure virtual function struct packed { logic a; logic [2:0] b; } [1:0] f();
  endclass
endpackage
module dut (output logic [3:0] o);
  initial o = 4'h5;
endmodule
