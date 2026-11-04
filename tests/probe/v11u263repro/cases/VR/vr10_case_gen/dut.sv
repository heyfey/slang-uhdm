// § genLpArrRangeFirst263
module sub #(parameter logic [3:0] V = 0) (output logic [3:0] o);
  assign o = V;
endmodule
module top(output logic [3:0] o);
  case (1)
    1: begin : c
      localparam logic [3:0] T [2] = '{4'hB, 4'hC};
      sub #(.V(T[1])) u (.o(o));
    end
  endcase
endmodule
