// r10v99 ADVERSARIAL -- the CONTEXTS the law must NOT reach (and the one it
// must): ordinary procedural assignment, continuous assign, port connection,
// a condition, a concat, a replication, a function argument, a case item,
// a parameter default.
package pc99;
  typedef struct packed { logic [2:0] a3; logic [4:0] b5; } c_t;
  function automatic logic [7:0] f99(input c_t v); return v; endfunction
endpackage
module csub99 (input pc99::c_t p, output logic [7:0] o);
  assign o = p;
endmodule
module v99_ctx (input logic s, input logic [1:0] sel,
                output logic [7:0] o_sub,
                output pc99::c_t o_ca,
                output logic [7:0] o_proc,
                output logic [7:0] o_cat,
                output logic [7:0] o_rep,
                output logic [7:0] o_arg,
                output pc99::c_t o_case,
                output logic [7:0] o_par);
  localparam pc99::c_t PDEF = '{ a3 : '1, b5 : '0 };   // parameter default
  pc99::c_t t_proc, t_case;
  // continuous assign THROUGH a ternary -- the law's own shape
  assign o_ca = s ? '{ a3 : '1, b5 : '0 } : '{ a3 : 3'd1, b5 : 5'd1 };
  // port connection carrying a ternary of patterns
  csub99 u_sub (.p(s ? '{ a3 : '1, b5 : '0 } : '{ a3 : 3'd1, b5 : 5'd1 }), .o(o_sub));
  // procedural assignment
  always_comb t_proc = s ? '{ a3 : '1, b5 : '0 } : '{ a3 : 3'd1, b5 : 5'd1 };
  assign o_proc = t_proc;
  // inside a concat
  assign o_cat = { (s ? pc99::c_t'('{ a3 : '1, b5 : '0 }) : 8'h00) };
  // inside a replication
  assign o_rep = {2{ (s ? pc99::c_t'('{ a3 : '1, b5 : '0 }) : 8'h00) }}[7:0];
  // function argument
  assign o_arg = pc99::f99(s ? '{ a3 : '1, b5 : '0 } : '{ a3 : 3'd1, b5 : 5'd1 });
  // case item
  always_comb begin
    case (sel)
      2'd0    : t_case = '{ a3 : '1, b5 : '0 };
      2'd1    : t_case = s ? '{ a3 : '1, b5 : '1 } : '{ a3 : '0, b5 : '0 };
      default : t_case = '{ a3 : 3'd1, b5 : 5'd1 };
    endcase
  end
  assign o_case = t_case;
  assign o_par = PDEF;
endmodule
