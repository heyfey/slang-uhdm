// § nestedDefChainName193
module sub ();
  module inner (output logic [3:0] q);
    class c;
      int x;
      function int get();
        return x;
      endfunction
    endclass
    assign q = 4'd1;
  endmodule
endmodule
module dut (output logic [3:0] o);
  sub u_s ();
  assign o = 4'd0;
endmodule
