// § tpOvrTypedefStructSpan152
module sub #(parameter type T = logic) (input logic [5:0] a_i, output logic o);
    T q [2];
    assign q[0] = a_i;
    assign q[1] = a_i;
    assign o = ^q[0];
endmodule
module tb(output logic o);
    typedef struct packed { logic [3:0] x; logic [1:0] y; } my_t;
    sub #(.T(my_t)) d (.a_i('0), .o(o));
endmodule
