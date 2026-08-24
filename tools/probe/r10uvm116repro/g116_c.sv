// r10uvm116 arm C -- the MEMBER form (obj.randomize) in three spellings, the
// control the fence must not touch, plus std::randomize on plain scope vars.
class holder_c;
  rand shortint depth_c;
  rand shortint width_c;
endclass
module top_c;
  holder_c h_one;
  int lim_c;
  int free_x;
  int free_y;
  int st_c;
  initial begin
    h_one = new();
    if (!h_one.randomize())
      $display("c1");
    if (!h_one.randomize() with { depth_c < lim_c; })
      $display("c2");
    if (!h_one.randomize(depth_c))
      $display("c3");
    st_c = std::randomize(free_x, free_y);
    if (!std::randomize(free_x) with { free_x > 3; })
      $display("c4");
  end
endmodule
