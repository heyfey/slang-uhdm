// § tpOvrTypedefStructSpan152
module sub #(parameter type T = logic) (input logic [3:0] a_i, output logic o);
    T q;
    assign q.x = a_i;
    assign o = ^q.x;
endmodule
module tb(output logic o);
    typedef struct { logic [3:0] x; logic [1:0] y; } my_t;
    sub #(.T(my_t)) d (.a_i('0), .o(o));
endmodule
