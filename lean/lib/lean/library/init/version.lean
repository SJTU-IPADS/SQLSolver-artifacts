prelude
import init.data.nat.basic init.data.string.basic

def lean.version : nat × nat × nat :=
(3, 4, 2)

def lean.githash : string :=
"cbd2b6686ddb566028f5830490fe55c0b3a9a4cb"

def lean.is_release : bool :=
1 ≠ 0

/-- Additional version description like "nightly-2018-03-11" -/
def lean.special_version_desc : string :=
""
