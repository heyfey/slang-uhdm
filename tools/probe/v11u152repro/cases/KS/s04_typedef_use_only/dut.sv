// § tpOvrTypedefStructSpan152
module sub #(parameter type T = logic) (input logic [11:0] a_i, output logic o);
    typedef T [1:0] arr_t;
    arr_t q;
    assign q = a_i;
    assign o = ^q;
endmodule
module tb(output logic o);
    typedef struct packed { logic [3:0] x; logic [1:0] y; } my_t;
    sub #(.T(my_t)) d (.a_i('0), .o(o));
endmodule
