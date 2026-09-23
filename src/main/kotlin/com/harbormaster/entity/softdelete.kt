package com.harbormaster.entity;

import java.time.Instant
import jakarta.persistence.MappedSuperclass

@MappedSuperclass
abstract class SoftDeleteEntity(

    version_: Long? = null

) : AuditableEntity(version_) {

    open var deleted_: Boolean = false

    open var deletedBy_: String? = null

    open var deletedDate_: Instant? = null
}