// § tpPackedArrCaUnparent275 — an assignment in one instance only through a generate condition
module child #(parameter type T = struct packed { logic a; logic b; } [1:0], parameter bit K = 1) (input T i, output T o);
  if (K) begin : ga
    assign o = i;
  end else begin : gb
    always_comb o = i;
  end
endmodule
module dut (input logic [3:0] i, output logic [3:0] o1, o2);
  child #(.K(1)) u (.i(i), .o(o1));
  child #(.K(0)) w (.i(i), .o(o2));
endmodule
