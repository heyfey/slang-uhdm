// § tpOvrTypedefStructSpan152
module sub #(parameter type T = logic) (input logic a_i, output logic o);
    assign o = a_i;
endmodule
module tb(output logic o);
    typedef struct packed { logic [3:0] x; logic [1:0] y; } my_t;
    sub #(.T(my_t)) d (.a_i(1'b0), .o(o));
endmodule
