// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): block.with(
    fill: luma(230), 
    width: 100%, 
    inset: 8pt, 
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

#show figure: it => {
  if type(it.kind) != "string" {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    new_title_block +
    old_callout.body.children.at(1))
}

#show ref: it => locate(loc => {
  let target = query(it.target, loc).first()
  if it.at("supplement", default: none) == none {
    it
    return
  }

  let sup = it.supplement.text.matches(regex("^45127368-afa1-446a-820f-fc64c546b2c5%(.*)")).at(0, default: none)
  if sup != none {
    let parent_id = sup.captures.first()
    let parent_figure = query(label(parent_id), loc).first()
    let parent_location = parent_figure.location()

    let counters = numbering(
      parent_figure.at("numbering"), 
      ..parent_figure.at("counter").at(parent_location))
      
    let subcounter = numbering(
      target.at("numbering"),
      ..target.at("counter").at(target.location()))
    
    // NOTE there's a nonbreaking space in the block below
    link(target.location(), [#parent_figure.at("supplement") #counters#subcounter])
  } else {
    it
  }
})

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      block(
        inset: 1pt, 
        width: 100%, 
        block(fill: white, width: 100%, inset: 8pt, body)))
}



#let article(
  title: none,
  authors: none,
  date: none,
  abstract: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: (),
  fontsize: 11pt,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: "1",
  )
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)

  if title != none {
    align(center)[#block(inset: 2em)[
      #text(weight: "bold", size: 1.5em)[#title]
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[Abstract] #h(1em) #abstract
    ]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}
#show: doc => article(
  title: [Manuscript 1],
  authors: (
    ( name: [Andreas Ludvig Ohm Svendsen],
      affiliation: [SDU],
      email: [alosvendsen\@health.sdu.dk] ),
    ( name: [Tore B. Stage],
      affiliation: [],
      email: [] ),
    ),
  date: [2024-02-09],
  abstract: [This is an abstract …

],
  toc_title: [Table of contents],
  toc_depth: 3,
  cols: 1,
  doc,
)


== Introduction
<introduction>
Inflammation is a complex biological response that is pivotal in various pathological conditions. These range from systemic inflammatory diseases, such as rheumatoid arthritis and sepsis, to lower-grade chronic inflammatory states such as type 2 diabetes mellitus. Given the prevalence of systemic inflammation, understanding its interaction with drug metabolism is of substantial clinical relevance.

Drug-metabolizing enzymes and transporters \(DMETs), predominantly found in hepatocytes within the liver, are central to the biotransformation of a wide variety of compounds. Inflammation has been shown to modulate the activity of these DMETs, a phenomenon that could potentially affect the pharmacokinetics of numerous medications. For individuals with altered inflammatory status—whether due to a chronic condition like diabetes or an acute event like sepsis—this modulation can have significant implications. It may necessitate adjustments in drug dosages to avoid adverse effects or therapeutic failure.

Previous research has provided valuable insights into the effects of inflammation on DMETs, but a clear correlation between in vitro studies and clinical observations remains elusive. For instance Dunvald et al. #cite(<dunvald>) conducted a comprehensive review of the clinical and in vitro evidence on inflammation-mediated modulation of DMETs and the impact on drug metabolism in humans. They found that in vitro studies in primary human hepatocytes revealed strong evidence of downregulation of key cytochrome P450 \(CYP) enzymes by inflammatory cytokines such as IL-6 and IL-1β. However, these studies often employed supraphysiological cytokine doses, which may not accurately represent the inflammatory conditions observed in patients.

Levels of IL-6 and IL-1B in healthy individuals are generally low, with reports in range of \~10pg/ml in adults for IL-6, and \~2.5 pg/ml IL-1B in adults #cite(<kim2011>);#cite(<kleiner2013>);#cite(<said2021>);#cite(<strand2020>);. In contrast, cytokine levels may be considerably elevated with IL-6 levels of \~140 pg/mL, and I#underline[L-1B levels of \~100 pg/mL];, among patients with rheumatoid arthritis or SLE #cite(<umare2014>) to more than 1 ng/mL of IL-6 for patients with acute inflammation caused by sepsis #cite(<franco2019>);. These variations in cytokine levels, which span a wide range in different pathological states, highlight the complex and dynamic nature of inflammation and underscore the need for research that considers this variability when investigating the effects of inflammation on drug-metabolizing enzymes.

Recently, 3D primary human hepatocytes \(PHH) have challenged 2D PHH as a more physiologically relevant culture method of PHH. 3D culture leads to more stable cell cultures that retain their hepatic phenotype for extended periods of time #cite(<bell2016>);. Consequently, this 3D PHH have been shown to predict CYP induction and hepatotoxicity more accurately than 2D PHH #cite(<bell2018>);#cite(<järvinen2023>);. Historically, 2D PHH have been utilized to study the effect of drugs and inflammation on hepatocyte/liver function. However, the inherent limitations of 2D cultures, primarily their inability to maintain the physiological phenotype and liver-specific functions of hepatocytes, have prompted a shift towards the 3D liver spheroid models. This model is increasingly recognized for their physiological relevance and stability, offering a more accurate representation of hepatic responses. The 3D liver spheroids preserve liver cell phenotypes and functions over extended periods, thereby enhancing the reliability of drug-induced liver injury predictions and disease mechanism investigations. This advancement positions 3D liver spheroids as potentially the new standard for in vitro hepatocyte studies, while still being suitable for a high throughput setting, and financially accessible as opposed to even more advanced liver models \(ref for last part) #cite(<ingelman-sundberg>);#cite(<dunvald>) . Another claim for the lack of correlation discussed in the review by AC et al.~is that there might be methodological limitations to the widespread use of 2D models of PHHs #cite(<dunvald>);.

We aimed to utilize 3D primary human hepatocytes #cite(<bell2016>) to study the impact of physiologically relevant concentrations of cytokines on CYP expression and activity. This may help further our understanding of the impact of inflammation on clinical drug metabolism among patients with inflammation. This, in turn, may inform more precise and adaptive prescribing strategies for patients in various inflammatory states.

== Methods
<methods>
=== 3D spheroid culture of PHHs
<d-spheroid-culture-of-phhs>
==== Materials
<materials>
All necessary components for cell culture, including the medium, supplements, and compounds, were acquired from Thermo Fisher Scientific, unless stated otherwise.

==== Cell source and preparation
<cell-source-and-preparation>
Three lots of cryopreserved primary human hepatocytes, specifically Hu8345-A, Hu8373-A and Hu8381, were procured from Thermo Fisher Scientific \(Waltham, MA). All necessary cell culture reagents were sourced from the same supplier. All PHHs were qualified for spheroid formation per the manufacturer.

==== Spheroid formation and maintenance
<spheroid-formation-and-maintenance>
The spheroid culture followed an adapted protocol from a previous study #cite(<bell2016>);. In short 1500 hepatocytes per well in ultra-low attachment 96-well plates. Following seeding, the plates were centrifuged for 2 minutes at 200g. Subsequently, the plates were incubated at 37°C with 5% CO2.

On day 0 cells were seeded in culture medium, totaling 100 μL per well, consisting of 5% fetal bovine serum, 1 μM dexamethasone, 5 μg/mL human recombinant insulin, 100 U/mL penicillin, 100 μg/mL streptomycin, 2 mM L-glutamine, and 15 mM HEPES in Williams’ E medium.

After spheroid formation the seeding medium was replaced with FBS free maintenance medium. This medium comprised 0.1 μM dexamethasone, 10 μg/mL human recombinant insulin, 5.5 μg/mL transferrin, 6.7 ng/mL selenium, 100 U/mL penicillin, 100 μg/mL streptomycin, and 2 mM L-glutamine in Williams’ E medium. This FBS washout with maintenance medium was done with a 70% medium change on days 5-7. `For donor 1 (Hu8345-A) the maintenance also contained 5.35 μg/mL linoleic acid, 1.25 mg/mL bovine serum albumin and 15 mM HEPES. These supplements are, however, no longer recommended by the manufacturer`#footnote[Skip this?];`.`

Detailed descriptions of the spheroid culture process, as well as donor information, are available in the supplementary materials \(Table SX).

=== Treatments
<treatments>
Treatment with proinflammatory cytokines commenced on day 8 post seeding. The spheroids were exposed to IL-6 and IL-1β at concentrations of 0.01, 0.1, 1, and 10 ng/ml, alongside a vehicle control \(0.1% bovine serum albumin in PBS). The cytokine treatments and vehicle control were diluted 1:1000 in the culture medium before administration.Re-dosing was done every other day for long-term cultures.

=== Spheroid viability and morphology
<spheroid-viability-and-morphology>
The viability of the spheroids was monitored by measuring their ATP content, using the luminiscence CellTiter-Glo 3D assay from Promega \(Madison, WI). Quantification of ATP was done using an ATP \(from Thermo Fisher Scientific) standard curve. Viability was assessed every 2-3 days throughout the experiments.

In addition to viability testing, the morphology of the spheroids was monitored. Imaging was done every second or third day, aligning with the viability assays. The spheroids were imaged using a light microscope equipped with a 10X magnification lens and a digital camera from Motic \(Hong Kong, China).

=== RNA extraction, cDNA synthesis and qPCR
<rna-extraction-cdna-synthesis-and-qpcr>
RNA was extracted using the phenol-chloroform method, following the manufacturer’s protocol from Qiagen with minor modifications #cite(<toni2018>);. Each spheroid pool was treated with 1 mL of Qiazol \(Qiagen) reagent for lysis, followed by co-precipitation with 15 μg of RNA grade glycogen \(Thermo Fisher Scientific). The RNA pellet underwent three washes with 75% ethanol. Post-wash, a combination of heating and evaporation techniques was applied to remove residual ethanol and to facilitate the solubilization of the RNA pellet in water.

RNA integrity was assessed for a subset of samples#footnote[Dog ikke fra nogle af disse 3 donorer, så måske bedre med: To assess the integrity of the RNA, we evaluated the RNA Integrity Number \(RIN) for a subset of samples, which yielded values ranging from 7 to 9.8. \
\
To validate the RNA extraction method, we assessed the RNA Integrity Number \(RIN) using the Agilent BioAnalyzer for a subset of samples not derived from the donors discussed in this article. These assessments yielded RIN values between 7 and 9.8, indicative of high-quality RNA.] using the Agilent BioAnalyzer, yielding RNA Integrity Number \(RIN) values from 7 to 9.8. These values indicate high-quality RNA. Concentration of RNA were estimated utilizing the NanoDrop spectrophotometer.

Approximately 500 ng of extracted RNA was used for cDNA synthesis. This process was performed using the High-Capacity cDNA Reverse Transcription Kit with RNase Inhibitor \(Thermo Fisher Scientific).

For qPCR, 10 ng of cDNA, based on the initial RNA concentration, was utilized for each reaction. The reactions were set up in a 10 μL volume containing TaqMan Universal Master Mix II and target-specific TaqMan assays \(detailed in Supplementary Methods). The qPCR was run for 40 cycles, following the manufacturer’s guidelines \(Thermo Fisher Scientific). The PCR plate sample maximization method was applied#cite(<derveaux2010>);, and a stable reference gene as well as no template controls and no reverse transcriptase controls was included in each plate.

In the analysis of mRNA expression, the relative quantity was calculated by first determining the delta Cq \(\(C\_q)) for each sample. This was achieved by subtracting the mean Cq of the control group from the mean Cq of the replicates of each sample. The relative quantity was then computed using the formula \(2^{C\_q}). For normalization, the relative quantity of the target gene in each sample was divided by the relative quantity of the reference gene \(GAPDH or TBP). The average normalized expression for each biological group was subsequently calculated.

=== Activity
<activity>
To assess the activity of CYP3A4 \(maybe otheres also), an experiment was conducted using midazolam as a substrate in spheroids derived from donors 2 and 3, evaluated on day 12. Midazolam \(Toronto Research Chemicals, Toronto, ON, Canada), was prepared as a 6,000× stock solution in DMSO. The final DMSO concentration in the enzyme activity assays was maintained at 0.15%. Prior to the introduction of midazolam to the spheroids, the cells underwent three washes with 100 μL of maintenance medium. Between washes, the residual volume was kept at 20 μL, and before the final wash, the spheroids were incubated for 2 hours in a cell culture incubator.

The concentration of midazolam in the assay was set at 10 μM, with a total volume of 100 μL per well. For the analysis, triplicate samples, each comprising a #strike[spheroid] and medium from a single well, were collected at 0.5 \(8 hours for other enzymes) hours post midazolam treatment. These samples were then stored at -80°C until further analysis. The specific methods used for the metabolite analysis of these samples are detailed in the supplementary material.

=== Quantitative analysis of proteins via LC-MS with selective immunoprecipitation
<quantitative-analysis-of-proteins-via-lc-ms-with-selective-immunoprecipitation>
The quantification of human CYP #strike[and transporter] proteins was performed using a targeted liquid chromatography-mass spectrometry approach, incorporating selective immunoprecipitation of peptides, as previously described#cite(<weiß2018>);. Uniform numbers of spheroids were employed in each analysis for consistency. In summary, spheroids were lysed in a buffer of 42 mM ammonium bicarbonate, containing 1.14 mM dithiothreitol and 9 mM iodoacetamide, and incubated for 15 minutes at 90°C, a method adapted from Savaryn et al. #cite(<savaryn2020>);. The lysates were then digested with MS-grade Pierce Trypsin Protease \(Thermo Fisher Scientific) for 16 hours at 37°C. To halt the digestion, phenylmethanesulfonyl fluoride was added to each sample, achieving a final concentration of 1 mM and a total volume of 70 μL. A portion of the digested sample \(25 μL) was then used for the immunoprecipitation of surrogate and internal standard peptides using triple X proteomics antibodies#cite(<weiß2018>);. These peptides were subsequently analyzed and quantified through LC-MS. The specific surrogate peptides employed for protein quantification and the LC-gradients are detailed in the supplementary material. For data processing, Skyline software \(MACOSS Lab, University of Washington, Seattle, WA) and TraceFinder 4.1 \(Thermo Fisher Scientific) were utilized.

== Results
<results>
=== Viability and morphology
<viability-and-morphology>
in @fig-viability we see that a relatively stable viability during the first 9 days of culture, and stayed above 60 percent of the variability after spheroids formation. Viability for donor was stable throughout the experiment, for the timepoints measured. Donor 12 was stable for the first 9 days of the experiment, with a slight dropoff seen from day 12, but stable hereafter., never dropping below 60 % of the viability after spheroid formation. Donor 3 was stable for the first 12 days, with a slight dropoff hereafter. Furthermore, morpholgy was consistent throughout the experiment, disregardign a tendency for the spheroids to shrink during the experimentm, which might be due to compaction or shedding of cells?\(main speroid article had atp relative to size).

Some loss of viability or metabolic activity cannot be ruled out, however this should not be a major concern since we are looking at relative data within each timepoints.

Within nine days from seeding the spheroid has formed and exhibit a tightly compacted appearance.

We used ATP content as a proxy for viability. Viability and morphology for

#figure([
#box(width: 923.9635258358662pt, image("images/morph.png"))
], caption: figure.caption(
position: bottom, 
[
Morphology for donors one, two, and three. Photos from the same well for each donor throughout the experiment. Scale bars represent 200 µm.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-morph>


#figure([
#box(width: 505.57993730407526pt, image("notebooks/viability/output/viability.png"))
], caption: figure.caption(
position: bottom, 
[
"Each point is the mean ATP content of 5-8 spheroids/replicates \(mean \= 7). There is no data for for donor 1 on day 5 and 16. Data for donor 3 day 9 was measured on day 10"
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-viability>


=== Effect of inflammatory cytokines on mRNA expression
<effect-of-inflammatory-cytokines-on-mrna-expression>
The treatments did not have a negative effect on the viability or morphology of the spheroids.

== Supplementary
<supplementary>
#block[
#block[
#block[
#figure([
#box(width: 506.6387434554974pt, image("index_files/figure-typst/notebooks-viability-Viability-fig-viability-relative-overall-output-1.png"))
], caption: figure.caption(
position: bottom, 
[
Note that the concentration of ATP of donor one on day 5 was to high. Data for this donor/day not trustworthy/viability to high. This yields a steep fall from day 5 to 7
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-viability-relative-overall>


]
]
]
#block[
#block[
#block[
#figure([
#box(width: 723.7696335078534pt, image("index_files/figure-typst/notebooks-viability-Viability-fig-donor-viabilities-output-2.png"))
], caption: figure.caption(
separator: "", 
position: bottom, 
[
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-donor-viabilities>


]
]
]
Mødes den 13. klokkwn 10-10.15 eller 8.30.

Send artikel inden frokost.. Tore læser og laver en struktur til diskussion, og sender tilabage idag. Jeg går igang med vulkanplot il-6 vs control.

#bibliography("references.bib")

