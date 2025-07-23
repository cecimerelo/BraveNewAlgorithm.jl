# BraveNewAlgorithm

This is a metaheuristic that is inspired by Brave New World and its specific caste system and way of reproduction. It tries to improve the exploitation/exploration balance of population-based metaheuristics by using different castes for every purpose.

If you want to use it, we kindly ask you to cite the following paper:

```bibtex
@Inbook{Merelo2022,
author="Merelo, Cecilia
and Merelo, Juan J.
and Garc{\'i}a-Valdez, Mario",
editor="Castillo, Oscar
and Melin, Patricia",
title="A Brave New Algorithm to Maintain the Exploration/Exploitation Balance",
bookTitle="New Perspectives on Hybrid Intelligent System Design based on Fuzzy Logic, Neural Networks and Metaheuristics",
year="2022",
publisher="Springer International Publishing",
address="Cham",
pages="305--316",
abstract="At the beginning of this year one of the authors read ``A brave new world'', a novel by Aldous Huxley. This book describes a dystopia, which anticipates the development of world-scale breeding technology, and how this technology creates the optimal human race. Taking into account that when talking about genetic algorithms our goal is to achieve the optimum solution of a problem, and this book kind of describes the process for making the ``perfect human'', or rather the ``perfect human population'', we will try to work on this parallelism in this paper, trying to find what is the key to the evolution processes described in the book. The goal is to develop a genetic algorithm based on the fecundation process of the book and compare it to other algorithms to see how it behaves, by investigating how the division in castes affects the diversity in the poblation. In this paper we describe the implementation of such algorithm in the programming language Julia, and how design and implementation decisions impact algorithmic and runtime performance.",
isbn="978-3-031-08266-5",
doi="10.1007/978-3-031-08266-5_20",
url="https://doi.org/10.1007/978-3-031-08266-5_20"
}
```

## Installation

```julia
using Pkg
Pkg.add("BraveNewAlgorithm")
```

## License

(c) Cecilia Merelo, 2021, released under the [GNU General Public License](LICENSE).