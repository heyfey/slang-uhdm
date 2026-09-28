// § lvIdxMemberSelIsRead184: a member path ending in a select in a compound-assignment target's index, in a class method's lvalue index and in an inc/dec operand's index
package pk;
  typedef struct packed { logic [3:0][2:0] f; } s_t;
  class c;
    s_t s;
    logic [7:0][7:0] arr;
    function void run(logic [1:0] k);
      arr[s.f[k]] += 2;
      arr[s.f[k + 1]] = 5;
      arr[s.f[k]]++;
    endfunction
  endclass
endpackage
module top (input logic [1:0] k, output logic [7:0] o);
  typedef struct packed { logic [3:0][2:0] f; } s_t;
  s_t s;
  logic [7:0][7:0] arr;
  always_comb begin
    arr[s.f[k]] = 0;
    arr[s.f[k]] |= 3;
  end
  assign o = arr[0];
endmodule
