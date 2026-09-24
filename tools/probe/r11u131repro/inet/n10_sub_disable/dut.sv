// § implicitNetMintNoFile131
module sub(output logic o);
  initial begin : loop
    o = 1'b0;
    disable loop;
  end
endmodule
module top(output logic o);
  sub u(.o(o));
endmodule
