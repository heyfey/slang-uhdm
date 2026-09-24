// § defNetTypeParamPackedDim144
typedef struct packed { logic a; logic [2:0] b; } s_t;
module sub #(parameter type T = s_t) (output logic o);
    T [1:0] x;
    wire T [1:0] w;
    assign x = '0;
    assign w = '1;
    assign o = x[0].a ^ w[1].a;
endmodule
module top(output logic o1, o2);
    typedef struct packed { logic a; } t2;
    sub u1(.o(o1));
    sub #(.T(t2)) u2(.o(o2));
endmodule
