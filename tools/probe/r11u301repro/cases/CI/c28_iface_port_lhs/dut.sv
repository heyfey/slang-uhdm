// § caInsideRhsClonesCell301
interface ifc;
  logic [3:0] a;
  logic o;
endinterface
module child (ifc i);
  assign i.o = i.a inside {[4'd1:4'd5]};
endmodule
module dut (output logic o);
  ifc u ();
  child c (.i(u));
  assign o = u.o;
endmodule
