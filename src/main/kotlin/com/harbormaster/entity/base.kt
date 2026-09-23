package com.harbormaster.entity;

import jakarta.persistence.MappedSuperclass
import jakarta.persistence.Version

@MappedSuperclass
abstract class BaseEntity(

    @Version
    open var version_: Long? = null

)