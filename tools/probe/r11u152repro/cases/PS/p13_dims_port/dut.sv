// § tpOvrTypedefStructSpan152
module sub #(parameter type T = logic) (input logic a_i, output T [1:0] o);
    assign o = '0;
endmodule
module tb(output logic [11:0] o);
    typedef struct packed { logic [3:0] x; logic [1:0] y; } my_t;
    sub #(.T(my_t)) d (.a_i(1'b0), .o(o));
endmodule
