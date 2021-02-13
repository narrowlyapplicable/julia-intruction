using DataFrames, Random, CSV, Statistics

grade_levels = ["F"; [x*y for x in 'D':-1:'A' for y in ["-", "", "+"]]]

Random.seed!(1);

## old
grades = categorical(rand(grade_levels, 100), ordered=true);
levels!(grades, grade_levels);
df = DataFrame(id=eachindex(grades), grades = grades);

## new
using CategoricalArrays
grades = categorical(rand(grade_levels, 100), ordered=true);
levels!(grades, grade_levels);
df = DataFrame(id=eachindex(grades), grades = grades);

isordered(grades)

levels(grades)

describe(df, :eltype)

filter(x -> x.grades > "A-", df)

download("https://openmv.net/file/class-grades.csv", "grades.csv")

## old
df = CSV.read("grades.csv");

## new
df = DataFrame!(CSV.File("grades.csv"));

summary(df)

describe(df, :min, :max, :nmissing)

## old
CSV.validate("grades.csv")

[cor(df[!, i], df[!, j]) for i in axes(df, 2), j in axes(df, 2)]

df2 = dropmissing(df);

describe(df2, :nmissing)

[cor(df2[!, i], df2[!, j]) for i in axes(df2, 2), j in axes(df2, 2)]

function cor2(x, y)
    df = dropmissing(DataFrame([x, y]))
    cor(df[!, 1], df[!, 2])
end

[cor2(df[!, i], df[!, j]) for i in axes(df, 2), j in axes(df, 2)]

## new
df = CSV.File("06. データフレームを使って分割‐適用‐結合を行う/iris.csv", footerskip=1, 
              header=["PetalLength", "PetalWidth", "SepalLength", "SepalWidth", "Class"]) |> DataFrame;

describe(df)

## old
by(df, :Class) do x
    DataFrame(n = nrow(x),
            mean = mean(x.SepalWidth),
            std = std(x.SepalWidth))
end

## new
gdf = groupby(df, :Class)
combine(gdf, :SepalWidth => mean)

combine(gdf, nrow, :SepalWidth => mean => :mean, :SepalWidth => std => :std)

df.id = axes(df, 1);

sdf = stack(df);
first(sdf, 3)

udf = unstack(sdf, :variable, :value);

names(udf)

## old
permutecols!(udf, names(df));
df == udf
## new
df == udf[:, names(df)]

df1 = DataFrame!(CSV.File("grades.csv"));
first(df1, 3)

Random.seed!(1)
df2 = df1[shuffle(axes(df1, 1)), shuffle(axes(df1, 2))];
first(df2, 3)

## old
res = join(df1, df2, kind=:outer,
            on=union(names(df1), names(df2)),
            indicator=:check, validate=(true, true))
unique(res.check)

## new
res = outerjoin(df1, df2, 
                on=union(names(df1), names(df2)),
                indicator=:check, validate=(true, true),
                matchmissing=:equal);
unique(res.check)


