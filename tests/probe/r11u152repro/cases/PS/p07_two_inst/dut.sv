// § tpOvrTypedefStructSpan152
module sub #(parameter type T = logic) (input T a_i, output logic o);
    T q;
    assign q = a_i;
    assign o = ^q;
endmodule
module tb(output logic o, output logic p);
    typedef struct packed { logic [3:0] x; logic [1:0] y; } my_t;
    my_t a;
    assign a = '0;
    sub #(.T(my_t)) d (.a_i(a), .o(o));
    sub #(.T(my_t)) e (.a_i(a), .o(p));
endmodule
