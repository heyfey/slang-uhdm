// § defaultFillImportCopies145 (control: a module-local default fill keeps one shared constant)
module top(output int o);
  localparam int unsigned V[2] = '{default: 3};
  assign o = V[1];
endmodule
