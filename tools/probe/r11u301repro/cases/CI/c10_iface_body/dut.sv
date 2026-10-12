// § caInsideRhsClonesCell301
interface ifc;
  logic [3:0] a;
  logic o;
  assign o = a inside {[4'd1:4'd5]};
endinterface
module dut (output logic o);
  ifc u ();
  assign o = u.o;
endmodule
