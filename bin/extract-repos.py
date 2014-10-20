from bsonstream import KeyValueBSONInput
import sys
from sys import argv
import gzip
from bson.json_util import dumps

f = sys.stdin
stream = KeyValueBSONInput(fh=f, fast_string_prematch="github")
for dict_data in stream:
    for k in dict_data.keys():
        if k.endswith('url'):
            dict_data.pop(k)

    dict_data.pop('_id')

    if 'permissions' in dict_data:
        dict_data.pop('permissions')

    dict_data['owner_id'] = dict_data['owner']['id']
    dict_data.pop('owner')

    for field in ['organization', 'parent', 'source']:
        if field in dict_data:
            dict_data[field + '_id'] = dict_data[field]['id']
            dict_data.pop(field)

    print dumps(dict_data)
