// § tpOvrTypedefStructSpan152
module sub #(parameter type T = logic, parameter type U = logic) (input T a_i, output logic o);
    U [1:0] q;
    assign q = '0;
    assign o = ^q ^ ^a_i;
endmodule
module tb(output logic o);
    typedef struct packed { logic [3:0] x; logic [1:0] y; } my_t;
    typedef struct packed { logic [2:0] z; } my2_t;
    sub #(.T(my_t), .U(my2_t)) d (.a_i('0), .o(o));
endmodule
