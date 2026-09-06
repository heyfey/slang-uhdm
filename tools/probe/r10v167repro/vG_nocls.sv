// r10v167 arm G - MODULE / INTERFACE / COMPILATION-UNIT homes WITHOUT a nested
// class (our emitter emits nothing for a class declared inside a module,
// interface or program - arm C measured that - so those homes only TEST this
// law through a class-free process), and 3 INSTANCES of the module home.
function automatic int uf167(int a, int b = 81, int c = 82);
  return a + b + c;
endfunction

class shU167 #(type T167 = int);
  int r;
  function void goU();
    r = uf167(1);
    r = uf167(T167::nm167);
    r = uf167(.a(T167::nm167), .c(9));
    r = uf167(.c(9), .a(T167::nm167));
    r = uf167(T167::nm167, 2, );
    r = uf167(1, 81, 82);
    r = uf167(T167::nm167, 81, 82);
  endfunction
endclass

interface iv167 #(parameter int Q = 1);
  int o;
  function int fi167(int a, int b = 0, int c = 7);
    return a + b + c;
  endfunction
  task ti167(int a, int b = 0);
    o = a + b;
  endtask
  generate
    if (Q == 1) begin : ilive
      always_comb o = fi167(1);
    end
    else begin : idead
      always_comb o = fi167(nosuch167::val);
      always_comb o = fi167(.a(nosuch167::val), .c(9));
      always_comb o = fi167(.c(9), .a(nosuch167::val));
      always_comb o = fi167(nosuch167::val, 2, );
      always_comb o = fi167(1, 0, nosuch167::val);
      initial ti167(nosuch167::val);
    end
  endgenerate
endinterface

module mg167 #(parameter int P = 1) (input logic clk, output int o);
  int r;
  function int gm167(int a, int b = 0, int c = 5);
    return a + b + c;
  endfunction
  task tg167(int a, int b = 0);
    r = a + b;
  endtask
  generate
    if (P == 1) begin : mlive
      always_comb o = gm167(1);
      always_comb o = gm167(.a(1), .c(9));
      always_comb o = uf167(1);
    end
    else begin : mdead
      always_comb o = gm167(nosuch167::val);
      always_comb o = gm167(.a(nosuch167::val), .c(9));
      always_comb o = gm167(.c(9), .a(nosuch167::val));
      always_comb o = gm167(nosuch167::val, 2, );
      always_comb o = uf167(nosuch167::val);
      always_comb o = uf167(.a(nosuch167::val), .c(9));
      always @(posedge clk) tg167(nosuch167::val);
    end
  endgenerate
endmodule

module tg167top (input logic clk, output int o1, output int o2, output int o3);
  iv167 #(.Q(1)) iu ();
  mg167 #(.P(1)) u1 (.clk(clk), .o(o1));
  mg167 #(.P(1)) u2 (.clk(clk), .o(o2));
  mg167 #(.P(1)) u3 (.clk(clk), .o(o3));
endmodule
