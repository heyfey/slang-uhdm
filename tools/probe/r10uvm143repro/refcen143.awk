# r10uvm143 — REFERENCE CENSUS: one row per ref_obj LISTING in a uhdm-dump —
# name, own loc, ENCLOSING printed object and its name, the FIELD it sits under,
# its vpiParent kind and its vpiActual kind.  The law reads the rows with
# enc=bit_select, fld=vpiIndex, par|enc naming a hier_path element.
# MEASUREMENT ONLY.  Keys never use a span for scoring (see score143.py).
#   usage: awk -f refcen143.awk <uhdm-dump output>
function indent(s,  n){ n=match(s,/[^ ]/); return n-1 }
{ line[NR]=$0; ind[NR]=indent($0) }
END{
  for(i=1;i<=NR;i++){
    if(line[i] !~ /^ *\\_ref_obj: /) continue
    d=ind[i]
    if(i>=NR || ind[i+1]!=d+2) continue
    nm=line[i]; sub(/^ *\\_ref_obj: \(/,"",nm); sub(/\),.*$/,"",nm); sub(/\)$/,"",nm)
    loc=line[i]; sub(/^ *\\_ref_obj: \([^)]*\), /,"",loc)
    fld="-"; for(k=i-1;k>=1;k--){ if(ind[k]==d && line[k] ~ /^ *\|/){ fld=line[k]; sub(/^ *\|/,"",fld); sub(/:.*$/,"",fld); break } if(ind[k]<d) break }
    enc="-"; encn="-"; for(k=i-1;k>=1;k--){ if(ind[k]==d-2 && line[k] ~ /^ *\\_/){ enc=line[k]; sub(/^ *\\_/,"",enc); sub(/:.*$/,"",enc); encn=line[k]; sub(/^ *\\_[a-z_]*: \(/,"",encn); sub(/\),.*$/,"",encn); sub(/\)$/,"",encn); break } if(ind[k]<d-2) break }
    par="-"; act="none"
    for(j=i+1;j<=NR && ind[j]>d;j++){
      if(ind[j]!=d+2) continue
      if(line[j] ~ /^ *\|vpiParent:/){ p=line[j+1]; sub(/^ *\\_/,"",p); sub(/:.*$/,"",p); par=p }
      if(line[j] ~ /^ *\|vpiActual:/){ a=line[j+1]; sub(/^ *\\_/,"",a); sub(/:.*$/,"",a); act=a }
    }
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n", nm, loc, enc, encn, fld, par, act
  }
}
