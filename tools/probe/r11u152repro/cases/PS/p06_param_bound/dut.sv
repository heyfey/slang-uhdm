// § tpOvrTypedefStructSpan152
module sub #(parameter type T = logic) (input T a_i, output logic o);
    assign o = ^a_i;
endmodule
module tb #(parameter int W = 4) (output logic o);
    typedef struct packed {
        logic [W-1:0] x;
        logic [1:0] y;
    } my_t;
    my_t a;
    assign a = '0;
    sub #(.T(my_t)) d (.a_i(a), .o(o));
endmodule
