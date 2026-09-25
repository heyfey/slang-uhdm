// § tpOvrTypedefStructSpan152
module sub_b #(parameter type T = logic) (input logic [11:0] a_i, output logic o);
    T [1:0] q;
    assign q = a_i;
    assign o = ^q;
endmodule
module sub_a #(parameter type T = logic) (input T [1:0] a_i, output logic o);
    assign o = ^a_i;
endmodule
module tb(output logic o, output logic p);
    typedef struct packed { logic [3:0] x; logic [1:0] y; } my_t;
    sub_a #(.T(my_t)) e (.a_i('0), .o(p));
    sub_b #(.T(my_t)) d (.a_i('0), .o(o));
endmodule
