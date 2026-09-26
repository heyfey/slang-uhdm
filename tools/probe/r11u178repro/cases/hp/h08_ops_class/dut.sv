// § hierPathSelIdxAtPath178
package pack;
typedef struct { string spath; } slice_t;
class concat_c; slice_t slices[]; endclass
class mam;
  function int g(int x); return x; endfunction
  function void check();
    concat_c path;
    foreach (path.slices[j]) begin
      string p_ = path.slices[j+1].spath;
      string q_ = path.slices[g(j)].spath;
      string r_ = path.slices[j].spath;
    end
  endfunction
endclass
endpackage
