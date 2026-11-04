// § spanCopyCarriesFile125
interface dl_if;
  logic q [0:2];
  assign q[0] = 1'b1;
endinterface
module top(output logic o);
  dl_if b();
  assign o = b.q[0];
endmodule
