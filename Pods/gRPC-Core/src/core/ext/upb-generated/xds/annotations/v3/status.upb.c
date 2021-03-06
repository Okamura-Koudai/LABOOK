/* This file was generated by upbc (the upb compiler) from the input
 * file:
 *
 *     xds/annotations/v3/status.proto
 *
 * Do not edit -- your changes will be discarded when the file is
 * regenerated. */

#include <stddef.h>
#include "upb/msg_internal.h"
#include "xds/annotations/v3/status.upb.h"
#include "google/protobuf/descriptor.upb.h"

#include "upb/port_def.inc"

static const upb_msglayout_field xds_annotations_v3_FileStatusAnnotation__fields[1] = {
  {1, UPB_SIZE(0, 0), 0, 0, 8, _UPB_MODE_SCALAR | (_UPB_REP_1BYTE << _UPB_REP_SHIFT)},
};

const upb_msglayout xds_annotations_v3_FileStatusAnnotation_msginit = {
  NULL,
  &xds_annotations_v3_FileStatusAnnotation__fields[0],
  UPB_SIZE(8, 8), 1, _UPB_MSGEXT_NONE, 1, 255,
};

static const upb_msglayout_field xds_annotations_v3_MessageStatusAnnotation__fields[1] = {
  {1, UPB_SIZE(0, 0), 0, 0, 8, _UPB_MODE_SCALAR | (_UPB_REP_1BYTE << _UPB_REP_SHIFT)},
};

const upb_msglayout xds_annotations_v3_MessageStatusAnnotation_msginit = {
  NULL,
  &xds_annotations_v3_MessageStatusAnnotation__fields[0],
  UPB_SIZE(8, 8), 1, _UPB_MSGEXT_NONE, 1, 255,
};

static const upb_msglayout_field xds_annotations_v3_FieldStatusAnnotation__fields[1] = {
  {1, UPB_SIZE(0, 0), 0, 0, 8, _UPB_MODE_SCALAR | (_UPB_REP_1BYTE << _UPB_REP_SHIFT)},
};

const upb_msglayout xds_annotations_v3_FieldStatusAnnotation_msginit = {
  NULL,
  &xds_annotations_v3_FieldStatusAnnotation__fields[0],
  UPB_SIZE(8, 8), 1, _UPB_MSGEXT_NONE, 1, 255,
};

static const upb_msglayout_field xds_annotations_v3_StatusAnnotation__fields[2] = {
  {1, UPB_SIZE(4, 4), 0, 0, 8, _UPB_MODE_SCALAR | (_UPB_REP_1BYTE << _UPB_REP_SHIFT)},
  {2, UPB_SIZE(0, 0), 0, 0, 14, _UPB_MODE_SCALAR | (_UPB_REP_4BYTE << _UPB_REP_SHIFT)},
};

const upb_msglayout xds_annotations_v3_StatusAnnotation_msginit = {
  NULL,
  &xds_annotations_v3_StatusAnnotation__fields[0],
  UPB_SIZE(8, 8), 2, _UPB_MSGEXT_NONE, 2, 255,
};

static const upb_msglayout *messages_layout[4] = {
  &xds_annotations_v3_FileStatusAnnotation_msginit,
  &xds_annotations_v3_MessageStatusAnnotation_msginit,
  &xds_annotations_v3_FieldStatusAnnotation_msginit,
  &xds_annotations_v3_StatusAnnotation_msginit,
};

extern const upb_msglayout google_protobuf_FieldOptions_msginit;
extern const upb_msglayout google_protobuf_FileOptions_msginit;
extern const upb_msglayout google_protobuf_MessageOptions_msginit;
extern const upb_msglayout xds_annotations_v3_FieldStatusAnnotation_msginit;
extern const upb_msglayout xds_annotations_v3_FileStatusAnnotation_msginit;
extern const upb_msglayout xds_annotations_v3_MessageStatusAnnotation_msginit;
const upb_msglayout_ext xds_annotations_v3_file_status_ext = {
  {226829418, 0, 0, 0, 11, _UPB_MODE_SCALAR | _UPB_MODE_IS_EXTENSION | (_UPB_REP_PTR << _UPB_REP_SHIFT)},
  &google_protobuf_FileOptions_msginit,
  {.submsg = &xds_annotations_v3_FileStatusAnnotation_msginit},

};
const upb_msglayout_ext xds_annotations_v3_message_status_ext = {
  {226829418, 0, 0, 0, 11, _UPB_MODE_SCALAR | _UPB_MODE_IS_EXTENSION | (_UPB_REP_PTR << _UPB_REP_SHIFT)},
  &google_protobuf_MessageOptions_msginit,
  {.submsg = &xds_annotations_v3_MessageStatusAnnotation_msginit},

};
const upb_msglayout_ext xds_annotations_v3_field_status_ext = {
  {226829418, 0, 0, 0, 11, _UPB_MODE_SCALAR | _UPB_MODE_IS_EXTENSION | (_UPB_REP_PTR << _UPB_REP_SHIFT)},
  &google_protobuf_FieldOptions_msginit,
  {.submsg = &xds_annotations_v3_FieldStatusAnnotation_msginit},

};

static const upb_msglayout_ext *extensions_layout[3] = {
  &xds_annotations_v3_file_status_ext,
  &xds_annotations_v3_message_status_ext,
  &xds_annotations_v3_field_status_ext,
};

const upb_msglayout_file xds_annotations_v3_status_proto_upb_file_layout = {
  messages_layout,
  extensions_layout,
  4,
  3,
};

#include "upb/port_undef.inc"

