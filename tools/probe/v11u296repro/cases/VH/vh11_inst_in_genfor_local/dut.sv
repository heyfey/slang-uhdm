// § hcTrailIdxNamesByPortChain296
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module sub4 (input logic [3:0] a, output logic y);
  assign y = a[0];
endmodule
module dut(output logic y, output logic y2, output logic y3);
  typedef struct packed {logic [31:0] f; logic [7:0] g;} st_t;
  for (genvar g = 0; g < 2; g++) begin : gb
    st_t ql; int il;
    logic yy;
    sub u (.a(ql.f[il]), .y(yy));
  end
  assign y = gb[1].yy; assign y2 = 0; assign y3 = 0;
endmodule
