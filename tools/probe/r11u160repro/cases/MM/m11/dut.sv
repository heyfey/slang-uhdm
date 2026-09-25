// § ppMacroBodyLines160
`define MARK(TYPE_, NAME_) \
    TYPE_ unused_fcov_``NAME_; \
    assign unused_fcov_``NAME_ = fcov_``NAME_;
`define SIG(TYPE_, NAME_, EXPR_) \
    TYPE_ fcov_``NAME_; \
    assign fcov_``NAME_ = EXPR_; \
    `MARK(TYPE_, NAME_)
module top(input logic a, input logic b);
  `SIG(logic, wb_valid, a & b)
endmodule
