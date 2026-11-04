// § ppOutputCol166
`define MARK(T_, N_) \
    T_ unused_``N_; \
    assign unused_``N_ = f_``N_;
`define SIG(T_, N_, E_) \
    T_ f_``N_; \
    assign f_``N_ = E_; \
    `MARK(T_, N_)
module top(input a, b);
  `SIG(logic, wb_valid, a & b)
endmodule
