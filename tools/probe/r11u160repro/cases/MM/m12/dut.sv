// § ppMacroBodyLines160
`define MARK(TYPE_, NAME_) \
    TYPE_ unused_fcov_``NAME_; \
    assign unused_fcov_``NAME_ = fcov_``NAME_;
module top(input logic a, input logic b);
  logic fcov_wb_valid;
  assign fcov_wb_valid = a & b;
  `MARK(logic, wb_valid)
endmodule
