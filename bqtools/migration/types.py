from enum import Enum


class Prefix(Enum):
    V = 'V'  # Versioned: regular
    U = 'U'  # Versioned: undo
    R = 'R'  # Repeatable
