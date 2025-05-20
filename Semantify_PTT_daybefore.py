"""
Author: Pedro Pimenta (ppimenta@umaia.pt)
Date: October, 2024
Description: This script processes electrical energy data and generates a turtle file
             representing event time series and energy datasets for a secondary substation (Maia PTT).
Context: This script is part of the OMEGA-X project and handles the transformation of data from a CSV file into a turtle file
         using the Omega-X Common Semantic data Model (https://github.com/OMEGA-X-EU/Omega-X-EDF). 
         Original code provided by Fatma Zohra HANNOU (fatma-zohra.hannou@edf.fr).

Updates:
- May 2025 - edited for clarity

"""

import csv
from rdflib import Graph, URIRef, Literal, Namespace
from rdflib.namespace import RDF, XSD
from datetime import datetime, timedelta

from rdflib import Graph, plugin
from rdflib.serializer import Serializer

#import rdflib_jsonld
#from rdflib.plugin import register, Serializer
#from rdflib_jsonld.serializer import Serializer

ETS = Namespace("https://w3id.org/omega-x/ontology/EventTimeSeries/")
PROP = Namespace("https://w3id.org/omega-x/ontology/Property/")
MAIA = Namespace("https://w3id.org/omega-x/KG/MaiaPTT/")
UNIT = Namespace("http://qudt.org/schema/qudt/Unit/")
EDS = Namespace("https://w3id.org/omega-x/ontology/EnergyDataset/")

# Graph definition and prefixes binding

g = Graph()
g.bind("ets", ETS)
g.bind("prop", PROP)
g.bind("maia", MAIA)
g.bind("eds", EDS)
g.bind("xsd", XSD)
g.bind("unit", UNIT)

# Main time series instance (device column)
mainTimeSeries = URIRef("https://w3id.org/omega-x/KG/MaiaPTT/TorreLidadorTimeSeries")

g.add((mainTimeSeries, RDF.type, ETS.TimeSeries))
g.add((mainTimeSeries, RDF.type, EDS.EnergyDataset))
g.add((mainTimeSeries, ETS.hasStep, Literal("PT1M", datatype=XSD.duration)))

# mapping column names to CSDM properties
property_mapping = {
    "CurrL1_A": PROP.CurrentL1,
    "CurrL2_A": PROP.CurrentL2,
    "CurrL3_A": PROP.CurrentL3,
    "ActPow_kW": PROP.ActivePower,
    "AppPow_kVA": PROP.ApparentPower,
    "ReacPow_kvar": PROP.ReactivePower,
    "Energy_kWh": PROP.Energy,
    "VolL1_V": PROP.VoltageL1,
    "VolL2_V": PROP.VoltageL2,
    "VolL3_V": PROP.VoltageL3,
    "THDUL1": PROP.TotalHarmonicDistorsionUL1,
    "THDUL2": PROP.TotalHarmonicDistorsionUL2,
    "THDUL3": PROP.TotalHarmonicDistorsionUL3,
    "THDIL1": PROP.TotalHarmonicDistorsionIL1,
    "THDIL2": PROP.TotalHarmonicDistorsionIL2,
    "THDIL3": PROP.TotalHarmonicDistorsionIL3,
    "cosphi": PROP.CosinusPhi
}

# adding unit names
unit_mapping = {
    "ActPow_kW": UNIT.KiloW,
    "AppPow_kVA": UNIT.KiloVA,
    "ReacPow_kvar": UNIT.kiloV,
    "CurrL1_A": UNIT.A,
    "CurrL2_A": UNIT.A,
    "CurrL3_A": UNIT.A,
    
    "THDUL1": UNIT.PERCENT,
    "THDUL2": UNIT.PERCENT,
    "THDUL3": UNIT.PERCENT,

    "THDIL1": UNIT.PERCENT,
    "THDIL2": UNIT.PERCENT,
    "THDIL3": UNIT.PERCENT,

    "VolL1_V": UNIT.V,
    "VolL2_V": UNIT.V,
    "VolL3_V": UNIT.V,
    "Energy_kWh": UNIT.KiloWHR,
    "cosphi": UNIT.PERCENT
}


# Given that timestamps are not expressed using iso format, a cleaning step is required.
def clean_time(timestamp):
    try:
        if "/" in timestamp and "(UTC" in timestamp:
            cleaned_str = timestamp.split('/')[0].strip() + ' ' + timestamp.split('/')[1].split('(UTC')[0].strip()
            dt = datetime.strptime(cleaned_str, "%H:%M %d.%m.%Y")
            dt = dt + timedelta(hours=1)
        else:
            dt = datetime.strptime(timestamp, "%Y-%m-%d %H:%M:%S")
        
        return dt.isoformat()  
    except ValueError as e:
        print(f"Error processing timestamp: {timestamp}, {e}")
        return None

# main function     
def semantify(csvFile):
    incrementing_id = 1 

    with open(csvFile, mode='r') as file:
        print ("... file opened")
        reader = csv.DictReader(file)
        for row in reader:
            realTime = clean_time(row['tstamp'])

            # digitalTime = clean_time(row['dstamp'])

            dataCollection = URIRef(f"https://w3id.org/omega-x/KG/MaiaPTT/DataCollection/{incrementing_id}")

            g.add((dataCollection, RDF.type, ETS.DataCollection))
            g.add((dataCollection, ETS.collectionTime, Literal(realTime, datatype=XSD.dateTime)))

            #g.add((dataCollection, ETS.creationTime, Literal(digitalTime, datatype=XSD.dateTime)))

            g.add((dataCollection, ETS.isElementOf, mainTimeSeries))

            if (incrementing_id%1000==0):
               print('incrementing_id', incrementing_id)
            for column, property in property_mapping.items():
                if column in row and row[column]:
                    dataPoint = URIRef(f"https://w3id.org/omega-x/KG/MaiaPTT/DataPoint/{column}/{incrementing_id}")
                    propertyValue = URIRef(f"https://w3id.org/omega-x/KG/MaiaPTT/PropertyValue/{column}/{incrementing_id}")

                    g.add((dataPoint, RDF.type, ETS.DataPoint))
                    g.add((dataPoint, ETS.belongsTo, dataCollection))
                    g.add((dataPoint, PROP.isAboutProperty, property))
                    g.add((dataPoint, PROP.hasUnit, unit_mapping[column]))

                    g.add((propertyValue, RDF.type, ETS.PropertyValue))

                    #print ("row[column]",row[column])
                    if (row[column]=='\\N'):
                        row[column]=0

                    #print ("propertyValue", propertyValue )
                    #print ("ETS.value", ETS.value )
                    
                    g.add((propertyValue, ETS.value, Literal(float(row[column]), datatype=XSD.float)))

                    g.add((dataPoint, ETS.hasDataValue, propertyValue))

            incrementing_id += 1

# Adaption to 'day before' 
# Get today's date
today = datetime.now()

# Calculate yesterday's date
yesterday = today - timedelta(days=1)

# Format and print yesterday's date
daybefore=yesterday.strftime('%Y-%m-%d')


# Source data file
csvFile = f'./PTT_daybefore/AllDevs_{daybefore}.csv'
print (f'Processing {csvFile}')
semantify(csvFile)

# The output format is set to: turtle. It can be changed to json-ld. In the latter case, the output file should be .json
output = g.serialize(format="turtle").decode('utf-8')

with open(f'./PTT_daybefore/AllDevs_{daybefore}.ttl', "w") as f: 
    f.write(output)

exit(0)
# Not used in the current version 
#
# output = g.serialize(format="json-ld")
#
# with open(f'./PTT_daybefore/AllDevs_{daybefore}.json', "w") as f: 
#    f.write(output)
