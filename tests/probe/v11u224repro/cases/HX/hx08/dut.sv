// § hpLvNewClassFirstElemSpan224
module top(output int o);
  class s; int x = 5; endclass
  class r; s parent; endclass
  typedef struct { r h; int k; } st_t;
  st_t st;
  initial begin
    st.h = new;
    st.h.parent = new;
    o = st.h.parent.x;
  end
endmodule
