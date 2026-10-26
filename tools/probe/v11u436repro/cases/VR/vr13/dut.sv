// § genClsNoDefRangeSyntax436
virtual class C #(parameter int N);
static function logic [N-1:0] f();
for (int i = 0; i < 2; i++) begin
  logic [N:0] y;
  y = '0;
end
f = '0;
endfunction
endclass
